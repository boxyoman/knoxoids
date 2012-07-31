//
//  vector.h
//  knoxoids
//
//  Created by Jonathan Covert on 6/17/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <math.h>

#ifndef knoxoids_vector_h
#define knoxoids_vector_h

template <typename type> class vector{
    public:
        type x;
        type y;
        
        vector();
        vector(double ang);
        vector(type, type);
        
        void set(type, type);
        
        double angle(vector);
        double distance(vector);
        double mag();
        double mag2();
        
        vector<double> unit();
        
        vector sign();
        
        vector operator + (vector);
        vector operator - (vector);
        vector operator * (double);
        vector operator / (double);
        vector operator * (vector);
        void operator = (vector);
        
        type dot(vector);
};

#endif
