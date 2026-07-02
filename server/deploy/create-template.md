# Publishing the one-click "Deploy on Railway" template

Railway's template creation is dashboard-only — there's no CLI/API path to
generate or publish a template (confirmed against the GraphQL API; only
`serviceInstanceUpdate`/create-style mutations exist for individual services,
nothing for the template object itself). This is a real 2-minute manual step,
not busywork:

1. Open the `tolowa-stash` project in the Railway dashboard (it already has
   all 4 hardened services: `postgres`, `stash`, `gateway`, `pg-backup`).
2. **Project Settings → Generate Template from Project.**
3. Configure the exposed variables Railway asks for: `STASH_TOKEN` (mark as
   "generate a value"), `STASH_OPENAI_API_KEY` (mark as required input),
   `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`S3_BUCKET`/`S3_ENDPOINT_URL`
   (mark `pg-backup` as optional — self-hosters may skip backups initially).
4. Set the template name to **Motion Memory Core**, description matching the
   repo README, and link back to
   [github.com/tolowa-studio/motion-memory-core](https://github.com/tolowa-studio/motion-memory-core).
5. **Publish.** Railway gives you a template URL
   (`railway.com/template/<id>`) and a markdown badge snippet.
6. Paste that badge into the root [`README.md`](../README.md) quickstart
   section and [`railway.md`](railway.md), replacing the "will be added here"
   note.

Once published, update `README.md`'s Quickstart section with:

```markdown
[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/template/<your-template-id>)
```
