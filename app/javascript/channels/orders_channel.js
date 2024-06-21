import consumer from "channels/consumer"

consumer.subscriptions.create("OrdersChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
  }
});
