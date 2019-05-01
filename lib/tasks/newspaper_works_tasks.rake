namespace :newspaper_works do
  def use_application
    ENV['RAILS_ENV'] = Rails.env if ENV['RAILS_ENV'].nil?
    Rails.application.require_environment!
  end

  desc 'Ingest an NDNP batch: "rake newspaper_works:ingest_ndnp -- --path="'
  task :ingest_ndnp do
    use_application
    puts ARGV
    ingester = NewspaperWorks::Ingest::NDNP::BatchIngester.from_command(
      ARGV,
      'rake newspaper_works:ingest_ndnp --'
    )
    ingester.ingest
  end
end
