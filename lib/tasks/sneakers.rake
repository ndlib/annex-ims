require 'sneakers'
require 'sneakers/runner'

task :environment

namespace :sneakers do
  class SneakersPidFileExists < StandardError
  end

  class SneakersWorkerError < StandardError
  end

  class SneakersRakeHelper
    class << self
      def sneakers_logger
        @sneakers_logger ||= Logger.new(STDOUT)
      end

      def info(message)
        sneakers_logger.info("[Sneakers Rake] #{message}")
      end

      def pid_file
        Rails.root.join('tmp/pids/sneakers.pid')
      end

      def pid_file_exists?
        File.exists?(pid_file)
      end

      def current_pid
        if pid_file_exists?
          pid_value = File.read(pid_file).strip
          if pid_value.present?
            pid_value.to_i
          end
        end
      end

      def process_running?(pid)
        begin
          if pid
            # Send a null signal to get the process status
            Process.kill(0, pid)
            true
          else
            false
          end
        rescue Errno::ESRCH
          false
        end
      end

      # Start and stop a worker to make sure it is functional
      def test_worker(worker_class)
        worker = worker_class.new
        begin
          Timeout::timeout(60) do
            worker.run
          end
          true
        rescue Timeout::Error
          raise SneakersWorkerError, "Timed out while testing #{worker_class}"
          false
        ensure
          worker.stop
        end
      end
    end
  end

  desc "Ensures that sneakers is running"
  task :ensure_running do
    SneakersRakeHelper::info "Ensuring sneakers is running"
    running = false
    if SneakersRakeHelper::pid_file_exists?
      pid = SneakersRakeHelper::current_pid
      if SneakersRakeHelper::process_running?(pid)
        running = true
      else
        timestamp = Time.now.strftime("%Y%m%d%H%M%S")
        broken_name = "#{SneakersRakeHelper::pid_file}.#{timestamp}"
        File.rename(SneakersRakeHelper::pid_file, broken_name)
        SneakersRakeHelper::info "PID file exists, but sneakers is not running. Moving broken PID file: #{broken_name}"
      end
    end
    if !running
      Rake::Task["sneakers:start"].invoke
    else
      SneakersRakeHelper::info "Sneakers already running"
    end
  end

  desc "Start sneakers workers as a background process"
  task :start do |t, args|
    SneakersRakeHelper::info "Starting sneakers in background"
    Process.fork do
      Rake::Task["sneakers:run"].invoke
    end
    SneakersRakeHelper::info "Started sneakers"
  end

  desc "Start the sneakers workers"
  task :run  => :environment do
    begin
      if SneakersRakeHelper::pid_file_exists?
        raise SneakersPidFileExists, "Sneakers pid file already exists: #{SneakersRakeHelper::pid_file}"
      end
      File.open(SneakersRakeHelper::pid_file, 'w') { |f| f.puts Process.pid }
      begin
        workers = []
        worker_classes = [
          ApiWorker,
          ItemMetadataWorker,
        ]
        worker_classes.each do |worker_class|
          SneakersRakeHelper::test_worker(worker_class)
          worker_class.number_of_workers.times do
            workers << worker_class
          end
        end

        runner = Sneakers::Runner.new(workers)

        runner.run
      ensure
        File.delete SneakersRakeHelper::pid_file
      end
    rescue SystemExit
      # Don't log SystemExit errors
      raise e
    rescue Interrupt
      # Don't log Interrupt errors
      raise e
    rescue Exception => e
      NotifyError.call(exception: e)
      raise e
    end
  end

  desc "Stop the sneakers background process"
  task :stop do
    if pid = SneakersRakeHelper::current_pid
      stopped = false
      SneakersRakeHelper::info "Stopping sneakers... (pid: #{pid})"
      if SneakersRakeHelper::process_running?(pid)
        Process.kill("TERM", pid)
        30.times do
          if SneakersRakeHelper::process_running?(pid)
            sleep(1)
          else
            stopped = true
            break
          end
        end
      else
        stopped = true
      end
      if stopped
        SneakersRakeHelper::info "Stopped sneakers"
      else
        SneakersRakeHelper::info "TERM sent to pid #{pid}, sneakers not stopped"
      end
    else
      SneakersRakeHelper::info "Sneakers not running"
    end
  end

  desc "Restart the sneakers background process"
  task :restart do
    SneakersRakeHelper::info "Restarting sneakers"
    Rake::Task["sneakers:stop"].invoke
    Rake::Task["sneakers:start"].invoke
  end
end
