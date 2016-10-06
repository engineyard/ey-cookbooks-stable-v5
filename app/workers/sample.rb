class Sample
  include Sidekiq::Worker
  def perform
    sleep 0.5
  end
end
