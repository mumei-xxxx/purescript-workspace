// import { stream } from '@stricjs/utils';
// import { Router } from '@stricjs/router';
import { Elysia } from "elysia";
import { staticPlugin } from "@elysiajs/static";

/**
 * @description
 * https://bun.sh/guides/ecosystem/stric
 * https://qiita.com/toshirot/items/829a04c36edeb30aec5d
 */
// export default new Router().get("/*", stream("./public"));
// .get('/', () => new Response('Hi'))
new Elysia().use(staticPlugin()).listen(8000);
