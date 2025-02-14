import { Elysia } from "elysia";
import { staticPlugin } from "@elysiajs/static";

/**
 * @description
 * https://bun.sh/guides/ecosystem/stric
 * https://qiita.com/toshirot/items/829a04c36edeb30aec5d
 */
new Elysia()
  .use(
    staticPlugin({
      // public ディレクトリを静的ファイルの配信元として設定
      assets: "public",
      // ルートパスへのアクセスを public ディレクトリにマッピング
      prefix: "/",
    })
  )
  .listen(8000, () => {
    console.log("🦊 Server is running at http://localhost:8000");
  });
