document.addEventListener("DOMContentLoaded", (event) => {
  const botSize = 10;
  const offset = botSize / 2;
  var url = 'ws://localhost:7654';
  var arenaElm = document.getElementById('arena');
  var arenaCtx = arenaElm.getContext("2d");
  var logElm = document.getElementById('log');
  function log(msg) {
    logElm.value += msg + "\n";
    logElm.scrollTop = logElm.scrollHeight;
  }
  log('Connecting to ' + url);
  var socket = new WebSocket(url);
  socket.addEventListener("open", (event) => {
    log("Connection open");
  });
  socket.addEventListener("close", (event) => {
    log("Connection closed");
  });
  socket.addEventListener("message", (event) => {
    console.log(event.data);
    var msg = JSON.parse(event.data);
    if (msg.type === 'arena_new') {
      arenaElm.style.visibility = 'visible';
      arenaElm.height = msg.height;
      arenaElm.width = msg.width;
    } else if (msg.type === 'bot_position') {
      arenaCtx.fillStyle = "blue";
      arenaCtx.fillRect(msg.x - offset, msg.y - offset, botSize, botSize);
    } else if (msg.type === 'tick') {
      arenaCtx.clearRect(0, 0, arenaElm.width, arenaElm.height);
    } else if (msg.type === 'game_over') {
      log('Game over');
    }
  });
});
