require 'csv'

namespace :annex do
  desc "Resolves issues in given csv"
  task :resolve, [:csv] => :environment do |t, args|
    Airbrake.configuration.rescue_rake_exceptions = true
    logger = Logger.new(STDOUT)

    if args.csv then
      text = File.read(args.csv)

      user = User.where(username: "hbeachey").take!

      csvData = CSV.parse(text, :headers => true)
      csvData.each do |row|
        id = row["issue id"]
        puts "#{id}"
        begin
          issue = Issue.find(id)
          ResolveIssue.call(user: user, issue: issue)
        rescue ActiveRecord::RecordNotFound => error
          puts "#{error}"
        end
      end
    end
  end
end
