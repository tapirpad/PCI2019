// auc_serial.cpp

#include <iostream>
#include <cmath>
#include <cstdlib>

int main(int argc, char** argv)
{
    const size_t ntot = (argc>1)?atoi(argv[1]):100;
    const double dx = 3.0/ntot;
    const double width = 3.0;

    double x = 0;
    double a = 0.0;

    for (size_t i=0; i<ntot; ++i) {
        const double y = 0.7*x*x*x - 2*x*x + 4;
        a += y*dx;
        x += dx;
    }

    std::cout << "The area is " << a << std::endl;

    return 0;
}

