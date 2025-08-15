import { Elysia } from "elysia";
import { Access } from "../models/access";

// Store for WebSocket connections by parkingId
const parkingConnections: Record<string, Set<any>> = {};

// Register a client for a specific parking
const registerClient = (parkingId: string, ws: any) => {
  if (!parkingConnections[parkingId]) {
    parkingConnections[parkingId] = new Set();
  }
  parkingConnections[parkingId].add(ws);
  console.log(`Client registered for parking ${parkingId}. Total: ${parkingConnections[parkingId].size}`);
};

// Unregister a client
const unregisterClient = (parkingId: string, ws: any) => {
  if (parkingConnections[parkingId]) {
    parkingConnections[parkingId].delete(ws);
    console.log(`Client unregistered from parking ${parkingId}. Remaining: ${parkingConnections[parkingId].size}`);
  }
};

// Broadcast to all clients connected to a specific parking
const broadcastToParkingClients = (parkingId: string, message: any) => {
  if (parkingConnections[parkingId]) {
    console.log(`Broadcasting to ${parkingConnections[parkingId].size} clients for parking ${parkingId}`);
    parkingConnections[parkingId].forEach(ws => {
      if (ws.readyState === 1) { // Check if connection is open
        ws.send(JSON.stringify(message));
      }
    });
  }
};

// Broadcast functions used by controllers
export const broadcastNewAccess = (parkingId: string, access: Access) => {
  broadcastToParkingClients(parkingId, {
    type: 'NEW_ACCESS',
    data: access
  });
};

export const broadcastAccessCompleted = (parkingId: string, access: Access) => {
  broadcastToParkingClients(parkingId, {
    type: 'ACCESS_COMPLETED',
    data: access
  });
};

export const broadcastSpotUpdate = (parkingId: string, spotId: string, isOccupied: boolean, accessId: string | null) => {
  broadcastToParkingClients(parkingId, {
    type: 'SPOT_UPDATE',
    data: {
      spotId,
      isOccupied,
      accessId
    }
  });
};

// WebSocket service
export const realtimeService = new Elysia()
  .ws('/ws/:parkingId', {
    open(ws) {
      const parkingId = ws.data.params.parkingId;
      if (!parkingId) {
        ws.close();
        return;
      }
      
      registerClient(parkingId, ws);
      
      // Send initial connection confirmation
      ws.send(JSON.stringify({
        type: 'CONNECTED',
        message: `Connected to realtime updates for parking ${parkingId}`
      }));
    },
    message(ws, message) {
      // Handle incoming messages if needed
      // console.log('Received message:', message);
      
      // Echo back for testing
      ws.send(JSON.stringify({
        type: 'ECHO',
        data: message
      }));
    },
    close(ws) {
      const parkingId = ws.data.params.parkingId;
      if (parkingId) {
        unregisterClient(parkingId, ws);
      }
    },
    error(error) {
      console.error('WebSocket error:', error);
    }
  }); 