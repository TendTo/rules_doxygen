/**
 * @file lib.h
 * @author Ernesto Casablanca (casablancaernesto@gmail.com)
 * @copyright 2024
 * @licence Apache-2.0 license
 */
#pragma once

/**
 * @brief Add two integers
 *
 * Who knows what the result will be?
 * @note This function is very complex. Use it with caution.
 * @warning The result can be greater than the maximum value that can be stored!
 * @param a First integer
 * @param b Second integer
 * @return Sum of a and b
 */
int add(int a, int b);

/**
 * @namespace doxylink_lib
 * @brief Namespace containing example classes and functions
 */
namespace doxylink_lib {

/**
 * @brief Example class for demonstration purposes
 * This class is used to demonstrate how to link documentation with Doxygen.
 */
class Example {
 public:
  /**
   * @brief Default constructor
   * This constructor does nothing.
   */
  Example() = default;
};

}  // namespace doxylink_lib
