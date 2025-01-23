import { t } from "elysia";
import { ParkingSchema } from "./parking";
import { LevelSchema } from "./level";
export const ParkingCompleteSchema = t.Composite([
  t.Omit(ParkingSchema, ['company']),
  t.Object({
    levels: t.Array(
      t.Composite([
        t.Omit(LevelSchema, ["parking"]),
      ])
    ),
  }),
]);

export type ParkingComplete = typeof ParkingCompleteSchema.static