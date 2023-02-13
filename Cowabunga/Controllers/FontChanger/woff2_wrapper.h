#pragma once
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
// Wraps woff2::ConvertTTFToWOFF2.
bool WOFF2WrapperConvertTTFToWOFF2(const uint8_t *data, size_t length,
                                   uint8_t *result, size_t *result_length);
#ifdef __cplusplus
}  // extern "C"
#endif
