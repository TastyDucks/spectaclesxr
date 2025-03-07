@component
export class Teleop extends BaseScriptComponent {
    @input
    remoteServiceModule: RemoteServiceModule;
    public static socket: WebSocket;

    async onAwake() {
        try {
            if (this.remoteServiceModule === undefined) {
                print("No RemoteServiceModule!");
            } else {
                Teleop.socket = this.remoteServiceModule.createWebSocket("wss://localhost:8080");
                Teleop.socket.binaryType = "blob";

                // Teleop.socket.onopen = (event: WebSocketEvent) => {
                    // Teleop.socket.send("Ping");
                // };
// 
                // Teleop.socket.onmessage = async (event: WebSocketMessageEvent) => {
                    // if (event.data instanceof Blob) {
                        // let bytes = await event.data.bytes();
                        // let text = await event.data.text();
                        // print("Received binary data: " + text);
                    // } else {
                        // print("Received data: " + event.data);
                    // }
                // };
// 
                // Teleop.socket.onclose = (event: WebSocketCloseEvent) => {
                    // if (event.wasClean) {
                        // print("Connection closed cleanly");
                    // } else {
                        // print("Connection died: " + event.code);
                    // }
                // };
// 
                // Teleop.socket.onerror = (event: WebSocketErrorEvent) => {
                    // print("Error: " + event);
                // };
            }
        } catch (e) {
            print("Error: " + e);
        }
    }
}

interface GestureData {
    hand: "l" | "r";
    origin: vec3;
    direction: vec3;
}

export class TargetHand extends BaseScriptComponent {
    private gesture: GestureModule = require("LensStudio:GestureModule");
    // If we are connected to the server, send over ray origins and directions
    onAwake() {
        this.gesture.getTargetingDataEvent(GestureModule.HandType.Right).add((args: TargetingDataArgs) => {
            this.sendData("l", args);
        });
        this.gesture.getTargetingDataEvent(GestureModule.HandType.Left).add((args: TargetingDataArgs) => {
            this.sendData("r", args);
        });
    }

    private sendData(hand: "l" | "r", args: TargetingDataArgs) {
        if (Teleop.socket?.readyState === 1 && args.isValid) {
            const data: GestureData = {
                hand: "r",
                origin: args.rayOriginInWorld,
                direction: args.rayDirectionInWorld
            };
            Teleop.socket.send(JSON.stringify(data));
        }
    }
}