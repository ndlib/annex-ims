require "csv"

namespace :annex do
  desc "Resolves issues in given csv"
  task :resolve, [:csv] => :environment do |_t, args|
    logger = Logger.new(STDOUT)

    if args.csv
      text = File.read(args.csv)

      user = User.where(username: "hbeachey").take!

      csvData = CSV.parse(text, headers: true)
      csvData.each do |row|
        id = row["issue id"]
        puts id.to_s
        begin
          issue = Issue.find(id)
          ResolveIssue.call(user: user, issue: issue)
        rescue ActiveRecord::RecordNotFound => e
          puts e.to_s
        end
      end
    end
  end
end
