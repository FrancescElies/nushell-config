# https://youtu.be/YXrb-DqsBNU?feature=shared&t=546
# https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html#available-checks
def compiler-flags [] {
  print "-Werror -Wall -Wextra -fsanitize=address,undefined,float-divide-by-zero,unsigned-integer-overflow,implicit-conversion,local-bounds,nullability" 
}

