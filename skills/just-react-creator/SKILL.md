---
name: just-react-creator
description: Publish Just React creator content with the public Course Builder cb CLI. Use when creating or updating Just React sketch posts, adding images to posts, uploading local images through signed S3 URLs, uploading videos/media through multipart upload, logging in to Just React, or exploring the Just React content API.
---

# Just React Creator

Use the public `cb` CLI as the paved path. Keep output token-safe: never print auth tokens, local config files, or signed URLs unless the user explicitly needs the URL for a script.

## Install and auth

If `cb` is missing, ask before installing or provide:

```sh
curl -fsSL https://github.com/badass-courses/coursebuilder-cli/releases/latest/download/install.sh | sh
```

Then authenticate:

```sh
cb auth login --app just-react
cb auth whoami --app just-react
```

For agent runs with an existing token, prefer environment variables:

```sh
export JRE_TOKEN="..."
cb auth whoami --app just-react --token "$JRE_TOKEN"
```

## Explore the API

Start with:

```sh
cb app list
curl -s https://www.justreact.dev/api/content-model | jq .
```

Just React creator content defaults to **post** resources for sketches/thoughts. Published public posts need:

```json
{
  "state": "published",
  "visibility": "public"
}
```

Use drafts/unlisted unless the user explicitly wants the post live.

## Create a sketch post

```sh
cb resource create \
  --app just-react \
  --body '{
    "type": "post",
    "title": "My sketch title",
    "fields": {
      "title": "My sketch title",
      "slug": "my-sketch-title",
      "body": "Markdown body goes here.",
      "state": "published",
      "visibility": "public"
    }
  }'
```

Save the returned `id` for updates and media attachment.

Verify:

```sh
cb resource get my-sketch-title --app just-react
```

## Add images to posts

Posts can reference images directly in Markdown:

```md
![Alt text](https://example.com/image.png)
```

### If the image is already hosted

Update the post body with a Markdown image reference:

```sh
cb resource update <post-id> \
  --app just-react \
  --body '{"fields":{"body":"Existing body\n\n![Alt text](https://example.com/image.png)"}}'
```

### If the image is local

Use the signed S3 upload URL flow. This stores the image in the Just React upload bucket and returns a public URL. Do **not** trigger video processing for images.

1. Get a signed upload URL:

```sh
cb creator upload signed-url \
  --app just-react \
  --object-name image.png
```

2. Parse `result.signedUrl` and `result.publicUrl` from the JSON response.

3. Upload the local file to the signed URL:

```sh
curl -fsSL -X PUT --upload-file ./image.png "$SIGNED_URL"
```

4. Add the public URL to the post body:

```md
![Alt text](PUBLIC_URL_FROM_RESPONSE)
```

5. Update the post:

```sh
cb resource update <post-id> \
  --app just-react \
  --body '{"fields":{"body":"Updated Markdown body with ![Alt text](PUBLIC_URL_FROM_RESPONSE)"}}'
```

## Upload video/media

For video files, use durable multipart upload. This uploads the file and triggers downstream processing:

```sh
cb creator upload file ./video.mp4 \
  --parent-resource-id <post-id> \
  --app just-react
```

Use `cb creator upload list-pending` if a large upload is interrupted.

## Safety rules

- Never print bearer tokens or `~/.config/coursebuilder/config.json`.
- Prefer `--token "$JRE_TOKEN"` in automation instead of pasting literal tokens.
- Create a tiny private/unlisted test post first when validating a new workflow.
- Use `state=published` and `visibility=public` only when the user confirms it should go live.
- For images, use signed URL upload plus Markdown. For videos, use `creator upload file`.
