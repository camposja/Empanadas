class SendMessageJob < ApplicationJob
  queue_as :default
  
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  def perform(message_id)
    message = Message.find(message_id)
    MessagingService.new.send_message(message)
  end
end
