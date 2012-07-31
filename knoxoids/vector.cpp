//
//  vector.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/17/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <iostream>
#include "vector.h"

template <typename type> vector<type>::vector(){ x = 0; y = 0;};

template <typename type> vector<type>::vector(double ang){ x = cos(ang); y = sin(ang);};

template <typename type> vector<type>::vector(type _x, type _y){ x = _x; y = _y;};

template <typename type> void vector<type>::set(type _x, type _y){ x = _x; y = _y;};

template <typename type> type vector<type>::dot(vector<type> a){ return x*a.x + y*a.y; };

template <typename type> vector<type> vector<type>::operator + (vector<type> a){
	vector<type> temp(x+a.x, y+a.y);
	return temp;
};

template <typename type> vector<type> vector<type>::operator - (vector<type> a){
	vector<type> temp(x - a.x, y - a.y);
	return temp;
};

template <typename type> vector<type> vector<type>::operator * (double a){
	vector<type> temp(x*a, y*a);
	return temp;
};
template <typename type> vector<type> vector<type>::operator / (double a){
	vector<type> temp(x/a, y/a);
	return temp;
};
template <typename type> vector<type> vector<type>::operator * (vector<type> a){
	vector<type> temp(x*a.x, y*a.y);
	return temp;
};

template <typename type> void vector<type>::operator = (vector<type> a){
    x = a.x;
    y = a.y;
};

template <typename type> vector<double> vector<type>::unit (){
	vector<double> temp(x,y);
	double mag = temp.mag();
	temp.x = x/mag;
	temp.y = y/mag;
	return temp;
};

template <typename type> vector<type> vector<type>::sign(){
	vector<type> temp(x, y);
	if(x>0){
		temp.x = 1;
	}else{
		temp.x = -1;
	}
	if(y>0){
		temp.y = 1;
	}else{
		temp.y = -1;
	}
	return temp;
};

template <typename type> double vector<type>::angle (vector<type> a){
	double temp = atan2(a.y - y, a.x - x);
	return temp;
};

template <typename type> double vector<type>::distance (vector<type> a){
	double temp = sqrt((a.x - x)*(a.x - x) + (a.y - y)*(a.y - y));
	return temp;
};
template <typename type> double vector<type>::mag (){
	double temp = sqrt((x)*(x) + (y)*(y));
	return temp;
};
template <typename type> double vector<type>::mag2 (){
	double temp = (x)*(x) + (y)*(y);
	return temp;
};

template class vector<int>;
template class vector<double>;
template class vector<float>;