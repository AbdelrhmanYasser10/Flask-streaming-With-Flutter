import cv2

def capture_screen():
    screen = cv2.VideoCapture(0)  # Open the default screen capture device (0 for the primary screen)
    
    while True:
        ret, frame = screen.read()  # Read a frame from the screen capture device
        if not ret:
            break
        
        # Process the frame as needed (e.g., resize, compress, etc.)
        
        # Convert the frame to bytes
        ret, buffer = cv2.imencode('.jpg', frame)
        
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n')
    
    screen.release()


from flask import Flask
from flask_sockets import Sockets

app = Flask(__name__)
sockets = Sockets(app)

@sockets.route('/stream')
def stream(ws):
    while not ws.closed:
        # Replace this with your video frame generation logic
        video_frame = capture_screen()

        # Send the video frame as a binary message to the WebSocket client
        ws.send(video_frame)

@app.route('/')
def index():
    return 'Hello, Flask!'

if __name__ == '__main__':
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler

    server = pywsgi.WSGIServer(('0.0.0.0', 5000), app, handler_class=WebSocketHandler)
    server.serve_forever()