/**
 * @file main.cpp
 * @author Ernesto Casablanca (casablancaernesto@gmail.com)
 * @copyright 2024
 */

#include <iostream>

#include "greet.h"
#include "greet_gen.h"
#include "lib.h"
#include "weird_header.h"

int main(int, char*[]) {
  std::cout << greet::generated_greeting() << std::endl;
  std::cout << greet::greeting_version << std::endl;
  int a = lib::pointless_identity<5>();
  int b = 10;
  std::cout << "a + b: " << lib::add(a, b) << std::endl;
  std::cout << "a - b: " << lib::sub(a, b) << std::endl;
  return 0;
}
