<?php

/**
 * @param mixed $event
 * @return array {statusCode: int, body: string}
 */

// @phpstan-ignore  missingType.iterableValue
function handler(mixed $event): array
{
    $name = $event['name'] ?? 'World';
    return [
        'statusCode' => 200,
        'body' => "Hello {$name}!"
    ];
}