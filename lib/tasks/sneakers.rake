require 'sneakers'
require 'sneakers/runner'

task :environment

namespace :sneakers do
  class SneakersAlreadyRunning < StandardError
  end

  def pid_file
    Rails.root.join('tmp/pids/sneakers.pid')
  end

  def sneakers_running?
    File.exists?(pid_file)
  end

  task :force_start do
    if sneakers_running?
      puts "Stopping existing sneakers process."
      Rake::Task["sneakers:force_stop"].invoke
    end
    Rake::Task["sneakers:start"].invoke
  end

  task :start do |t, args|
    puts "Starting sneakers in background"
    Process.fork do
      Rake::Task["sneakers:run"].invoke
    end
    puts "Started sneakers"
  end

  desc "Start work (set JOB_QUEUES=default,active_job_two,active_job_one)"
  task :run  => :environment do
    begin
      if sneakers_running?
        raise SneakersAlreadyRunning, "Sneakers already running: #{pid_file}"
      end
      File.open(pid_file, 'w'){|f| f.puts Process.pid}
      begin
        workers = []
        worker_classes = [
          ItemMetadataWorker,
        ]
        worker_classes.each do |worker_class|
          worker_class.number_of_workers.times do
            workers << worker_class
          end
        end

        runner = Sneakers::Runner.new(workers)

        runner.run
      ensure
        File.delete pid_file
      end
    rescue SystemExit
      # Ignore SystemExit errors
    rescue Exception => e
      NotifyError.call(exception: e)
      raise e
    end
  end

  task :stop do
    if sneakers_running?
      pid = File.read(pid_file).strip.to_i
      puts "Stopping sneakers..."
      Process.kill("INT", pid)
      stopped = false
      60.times do
        begin
          Process.kill(0, pid)
        rescue Errno::ESRCH
          stopped = true
          break
        end
        sleep(1)
      end
      if stopped
        puts "Stopped sneakers"
      else
        puts "INT sent to pid #{pid}, sneakers not stopped"
      end
    else
      puts "Sneakers not running"
    end
  end

  task :force_stop do
    Rake::Task["sneakers:stop"].invoke
    if sneakers_running?
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      broken_name = "#{pid_file}.#{timestamp}"
      puts "Moving broken PID file: #{broken_name}"
      File.rename(pid_file, broken_name)
    end
  end

  task :restart do
    Rake::Task["sneakers:stop"].invoke
    Rake::Task["sneakers:start"].invoke
  end
end
