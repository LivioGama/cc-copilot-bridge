#!/usr/bin/env bun

/**
 * Ollama Cloud Auth Proxy
 *
 * Converts Claude Code's x-api-key header format to Ollama Cloud's Bearer auth format.
 *
 * Claude Code CLI always sends: x-api-key: <token>
 * Ollama Cloud expects:         Authorization: Bearer <token>
 *
 * Usage:
 *   bun ./scripts/ollama-cloud-proxy.ts --port 4143
 *   ANTHROPIC_BASE_URL=http://localhost:4143 ccoc
 */

interface ProxyConfig {
  port: number;
  upstreamUrl: string;
}

const parseArgs = (): ProxyConfig => {
  const args = process.argv.slice(2);
  let port = 4143;
  let upstreamUrl = process.env.OLLAMA_API_ENDPOINT || "https://ollama.com";

  for (let i = 0; i < args.length; i++) {
    if (args[i] === "--port" && args[i + 1]) {
      port = parseInt(args[++i], 10);
    } else if (args[i] === "--upstream" && args[i + 1]) {
      upstreamUrl = args[++i];
    }
  }

  return { port, upstreamUrl };
};

const handleRequest = async (
  req: Request,
  upstreamUrl: string
): Promise<Response> => {
  try {
    // Extract the x-api-key header if present
    const apiKey = req.headers.get("x-api-key");
    if (!apiKey) {
      return new Response(
        JSON.stringify({
          error: "x-api-key header is required",
        }),
        { status: 401, headers: { "content-type": "application/json" } }
      );
    }

    // Create a new request to upstream with Bearer auth
    const upstreamPath = new URL(req.url).pathname + new URL(req.url).search;
    const upstreamReqUrl = `${upstreamUrl}${upstreamPath}`;

    // Clone and modify headers
    const newHeaders = new Headers(req.headers);
    newHeaders.delete("x-api-key"); // Remove x-api-key
    newHeaders.set("Authorization", `Bearer ${apiKey}`); // Add Bearer auth

    // Forward the request
    const upstreamReq = new Request(upstreamReqUrl, {
      method: req.method,
      headers: newHeaders,
      body: req.method !== "GET" && req.method !== "HEAD" ? req.body : undefined,
    });

    // Use tls option for development (Ollama Cloud may use self-signed or locally-trusted certs)
    const upstreamRes = await fetch(upstreamReq, {
      tls: {
        rejectUnauthorized: false,
      },
    } as Parameters<typeof fetch>[1]);

    // Copy response, preserving headers and status
    return new Response(upstreamRes.body, {
      status: upstreamRes.status,
      statusText: upstreamRes.statusText,
      headers: upstreamRes.headers,
    });
  } catch (error) {
    const errorMsg =
      error instanceof Error ? error.message : String(error);
    console.error(`[ERROR] Request failed: ${errorMsg}`);
    return new Response(
      JSON.stringify({
        error: "proxy_error",
        message: errorMsg,
      }),
      {
        status: 502,
        headers: { "content-type": "application/json" },
      }
    );
  }
};

const main = async () => {
  const config = parseArgs();

  console.log(`[INFO] Ollama Cloud Auth Proxy starting...`);
  console.log(`[INFO] Port: ${config.port}`);
  console.log(`[INFO] Upstream: ${config.upstreamUrl}`);
  console.log(
    `[INFO] Ready at http://localhost:${config.port}`
  );
  console.log(
    `[INFO] Set ANTHROPIC_BASE_URL=http://localhost:${config.port} before launching Claude Code`
  );

  const server = Bun.serve({
    port: config.port,
    fetch: (req) => handleRequest(req, config.upstreamUrl),
    error: (error) => {
      console.error(`[ERROR] Server error:`, error);
      return new Response("Internal Server Error", { status: 500 });
    },
  });

  console.log(`[INFO] Listening on http://localhost:${config.port}`);
};

main().catch((err) => {
  console.error("[FATAL]", err);
  process.exit(1);
});
