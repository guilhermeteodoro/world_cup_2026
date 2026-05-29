# Sticker catalog as a seeded table with a pivot for user collections

The album has a fixed set of 994 stickers that never changes. We seed a `stickers` table with all 994 rows (team, number, category, position) and use a `user_stickers` pivot table to track each user's collection. Row existence means "owned/glued," and a `copies` integer tracks tradeable extras.

We considered storing collections as PostgreSQL integer arrays or JSON blobs on the user row. The pivot table was chosen because it enables future features (trade confirmation as row manipulation, querying "who has sticker X as a duplicate") without schema changes, and maps cleanly to ActiveRecord associations.
