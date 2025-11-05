#include "mex.hpp"
#include "mexAdapter.hpp"
#include "hwm14Wrapper.h"

class HWM14Wrapper : public matlab::mex::Function { 
public:
    void operator()(matlab::mex::ArgumentList outputs, matlab::mex::ArgumentList inputs) {
        // Extract input arguments
        