require 'rubocop/rake_task'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = [
    '-c', 'config/style_guides/.ruby-style.yml',
    '--display-cop-names'
  ]
end