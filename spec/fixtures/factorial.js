alert("This code has a snippet below!");
factorial(3);

// BEGIN FACTORIAL_FUNC
function factorial(number) {
    if (number == 0) {
       return 1
       } else {
        return factorial(number - 1) * number
  }
}
// END FACTORIAL_FUNC
