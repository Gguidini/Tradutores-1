float main(){
	SumArray<float> s[10];
	MinArray<float> s1[10];
	MaxArray<float> s2[10];
	int i;
	i = 0;
	while(i < 10){
		s1[i, i] += i;
		s2[i, i] += i;
		s[i, i] += i;
		i += 1;
	}
	s[1, 3] += 57.523;
	s1[1, 3] += 57.523;
	s2[1, 3] += 57.523;

	float x;
	i = 0;
	float k;
	k = 3.3333333333333333;

	outFloat k;
	x = s[1, 3];
	outFloat x;
	x = s1[1, 3];
	outFloat x;
	x = s2[1, 3];
	outFloat x;
	outFloat k;

	x = s[1, 1];
	outFloat x;
	x = s1[1, 1];
	outFloat x;
	x = s2[1, 1];
	outFloat x;
	outFloat k;
	
	x = s[2, 2];
	outFloat x;
	x = s1[2, 2];
	outFloat x;
	x = s2[2, 2];
	outFloat x;
	outFloat k;
	
	x = s[1, 6];
	outFloat x;
	x = s1[1, 6];
	outFloat x;
	x = s2[1, 6];
	outFloat x;
	outFloat k;

	s[2, 5] += 5.444;
	x = s[1, 6];
	outFloat x;
	s1[2, 5] += 5.444;
	x = s1[1, 6];
	outFloat x;
	s2[2, 5] += 5.444;
	x = s2[1, 6];
	outFloat x;

	outFloat k;
	x = s[0, 6];
	outFloat x;
	x = s1[0, 6];
	outFloat x;
	x = s2[0, 6];
	outFloat x;
}
