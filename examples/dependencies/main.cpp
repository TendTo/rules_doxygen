/**
 * @file lib.cpp
 * @author Ernesto Casablanca (casablancaernesto@gmail.com)
 * @copyright 2024
 */

#include <iostream>

#include "lib.h"

int main(int, char*[]) {
  int a = 5;
  int b = 10;
  std::cout << "a + b: " << lib::add(a, b) << std::endl;
  std::cout << "a - b: " << lib::sub(a, b) << std::endl;
  return 0;
}
