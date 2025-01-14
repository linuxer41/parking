import { t } from "elysia";
import { ParkingSchema } from "./parking";
import { LevelSchema } from "./level";
import { AreaSchema } from "./area";
import { SpotSchema } from "./spot";

export const ParkingCompleteSchema = t.Composite([
  t.Omit(ParkingSchema, ['company']),
  t.Object({
    levels: t.Array(
      t.Omit(t.Composite([
        t.Omit(LevelSchema, ["parking"]),
        t.Object({
          areas: t.Array(
            t.Composite([
              t.Omit(AreaSchema, ["parking", "level"]),
              t.Object({
                spots: t.Array(
                  t.Omit(SpotSchema, ["area","parking"]),
                ),
              }),
            ])
          ),
        }),
      ]), ["parking"])
  ),
}),
]);

export type ParkingComplete = typeof ParkingCompleteSchema.static