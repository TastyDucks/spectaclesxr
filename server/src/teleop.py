import asyncio
import io
import json
from datetime import datetime

import websockets
from PIL import Image, ImageDraw, ImageFont


# Generate a dummy 720p frame with the current datetime rendered as text
async def generate_frame():
    # Create a 1280x720 white background image
    img = Image.new("RGB", (1280, 720), color=(255, 255, 255))
    draw = ImageDraw.Draw(img)
    # Get the current datetime as a string
    text = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    # Attempt to load a truetype font; fallback to default if not available
    try:
        font = ImageFont.truetype("arial.ttf", 60)
    except IOError:
        font = ImageFont.load_default()
    # Center the text
    text_width, text_height = draw.textsize(text, font=font)
    position = ((1280 - text_width) // 2, (720 - text_height) // 2)
    draw.text(position, text, fill=(0, 0, 0), font=font)
    # Save the image to a bytes buffer as JPEG
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    return buf.getvalue()


# Continuously send frames over the WebSocket as binary messages (interpreted as Blobs)
async def send_frames(websocket):
    while True:
        frame_bytes = await generate_frame()
        await websocket.send(frame_bytes)
        # Aim for ~10 frames per second (adjust as needed)
        await asyncio.sleep(0.1)


# Listen for incoming messages, parse as JSON, and print GestureData
async def receive_messages(websocket):
    while True:
        try:
            message = await websocket.recv()
            try:
                data = json.loads(message)
                # Expected gesture data structure:
                # { "hand": "l" | "r", "origin": [x, y, z], "direction": [x, y, z] }
                print("Received GestureData:", data)
            except json.JSONDecodeError:
                print("Received non-JSON message:", message)
        except websockets.exceptions.ConnectionClosed:
            print("Connection closed.")
            break


# WebSocket handler that spawns both send and receive tasks
async def handler(websocket, path):
    print(f"New connection from {websocket.remote_address}")
    send_task = asyncio.create_task(send_frames(websocket))
    recv_task = asyncio.create_task(receive_messages(websocket))
    # Wait until one of the tasks completes (or the connection closes)
    done, pending = await asyncio.wait(
        [send_task, recv_task], return_when=asyncio.FIRST_COMPLETED
    )
    # Cancel any remaining tasks
    for task in pending:
        task.cancel()


# Main entry point to start the WebSocket server
async def main():
    async with websockets.serve(handler, "0.0.0.0", 80):
        await asyncio.Future()  # run forever


if __name__ == "__main__":
    asyncio.run(main())
