namespace :db do
  namespace :seed do
    task :demo => :environment do
      load "#{Rails.root}/db/seeds/demo.rb"
    end
    task :site => :environment do
      load "#{Rails.root}/db/seeds/site.rb"
    end
  end
end