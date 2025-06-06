import Elysia, { t } from "elysia";
import { processNotifications } from "../utils/notification-sender";
import { accessPlugin } from "../plugins/access";

export const notificationProcessorController = new Elysia({ prefix: '/notification-processor', tags: ['notification-processor'], detail: { summary: 'Procesamiento de notificaciones', description: 'Endpoints para procesar notificaciones pendientes.', security: [{ branchId: [], token: [] }] } })
  .use(accessPlugin)
  .post('/process', async () => {
    try {
      await processNotifications();
      return { success: true, message: 'Notificaciones procesadas correctamente' };
    } catch (error) {
      console.error('Error processing notifications:', error);
      throw new Error('Error al procesar notificaciones');
    }
  }, {
    detail: {
      summary: 'Procesar notificaciones',
      description: 'Procesa todas las notificaciones pendientes.',
    },
    response: {
      200: t.Object({
        success: t.Boolean({
          description: "Indica si el procesamiento fue exitoso",
          required: true
        }),
        message: t.String({
          description: "Mensaje descriptivo del resultado",
          required: true
        })
      }),
      500: t.String(),
    },
  }); 