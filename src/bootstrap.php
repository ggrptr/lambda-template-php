<?php


// This invokes Composer's autoloader so that we'll be able to use Guzzle and any other 3rd party libraries we need.
require __DIR__ . '/../vendor/autoload.php';

// This is the request processing loop. Barring unrecoverable failure, this loop runs until the environment shuts down.
do {
    $uuid = uniqid('', true);
    // Ask the runtime API for a request to handle.
    echo "Getting next request {$uuid}\n";
    $request = getNextRequest();
    echo "{$request['invocationId']} -- {$uuid} \n";
    // Obtain the function name from the _HANDLER environment variable and ensure the function's code is available.
    $handlerFunction = array_slice(explode('.', $_SERVER['_HANDLER']), -1)[0];
    require_once $_SERVER['LAMBDA_TASK_ROOT'] . '/src/' . $handlerFunction . '.php';

    // Execute the desired function and obtain the response.
    $response = call_user_func($handlerFunction, $request['payload']);  // @phpstan-ignore argument.type

    // Submit the response back to the runtime API.
    echo "Sending response {$uuid}\n";
    sendResponse($request['invocationId'], $response);
} while (true); // @phpstan-ignore doWhile.alwaysTrue

/**
 * @return array{invocationId: string, payload: mixed}
 * @throws \GuzzleHttp\Exception\GuzzleException
 */
function getNextRequest(): array
{
    $client = new \GuzzleHttp\Client();
    $response = $client->get('http://' . $_SERVER['AWS_LAMBDA_RUNTIME_API'] . '/2018-06-01/runtime/invocation/next');

    return [
        'invocationId' => $response->getHeader('Lambda-Runtime-Aws-Request-Id')[0],
        'payload' => json_decode((string) $response->getBody(), true)
    ];
}

function sendResponse(string $invocationId, mixed $response): void
{
    // https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html#runtimes-api-response
    $client = new \GuzzleHttp\Client();
    $client->post(
        'http://' . $_SERVER['AWS_LAMBDA_RUNTIME_API'] . '/2018-06-01/runtime/invocation/' . $invocationId . '/response',
        [
            GuzzleHttp\RequestOptions::JSON => $response
        ]
    );
}