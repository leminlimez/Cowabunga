#include "woff2_wrapper.h"

#include <string>

// copied from woff2/include/encode.h
namespace woff2 {
struct WOFF2Params {
  WOFF2Params()
      : extended_metadata(""), brotli_quality(11), allow_transforms(true) {}

  std::string extended_metadata;
  int brotli_quality;
  bool allow_transforms;
};
bool ConvertTTFToWOFF2(const uint8_t *data, size_t length, uint8_t *result,
                       size_t *result_length, const WOFF2Params &params);
}  // namespace woff2

bool WOFF2WrapperConvertTTFToWOFF2(const uint8_t *data, size_t length,
                                   uint8_t *result, size_t *result_length) {
  return woff2::ConvertTTFToWOFF2(data, length, result, result_length, {});
}
