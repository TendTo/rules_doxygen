/**
 * @file lib.h
 * @author Ernesto Casablanca (casablancaernesto@gmail.com)
 * @copyright 2024
 */
#pragma once

/**
 * @brief Run a calculation on two integers.
 */
class Calculator {
 public:
  /**
   * @brief Run a calculation on two integers.
   *
   * The actual operation is defined by the derived class.
   * @param a first integer
   * @param b second integer
   * @return result of the operation
   */
  virtual int op(int a, int b) = 0;
};

/**
 * @brief Add two integers.
 */
class Adder : public Calculator {
 public:
  /**
   * @brief Add two integers.
   *
   * @param a first integer
   * @param b second integer
   * @return sum of a and b
   */
  int op(int a, int b) override;
};

/**
 * @brief Subtract two integers.
 */
class Subtractor : public Calculator {
 public:
  /**
   * @brief Subtract two integers.
   *
   * @param a first integer
   * @param b second integer
   * @return difference of a and b
   */
  int op(int a, int b) override;
};
