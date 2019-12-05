int main(){
	SumArray<int> s[10];
	MinArray<int> s1[10];
	MaxArray<int> s2[10];
	float i;
	i = 0;
	while(i < 10){
		s1[i, i] += i;
		s2[i, i] += i;
		s[i, i] += i;
		i += 1;
	}
	s[1, 3] += 100;
	s1[1, 3] += 100;
	s2[1, 3] += 100;

	int x;
	i = 0;
	float k;
	k = 3.3333333333333333;

	outFloat k;
	x = s[1, 3];
	outInt x;
	x = s1[1, 3];
	outInt x;
	x = s2[1, 3];
	outInt x;
	outFloat k;

	x = s[1, 1];
	outInt x;
	x = s1[1, 1];
	outInt x;
	x = s2[1, 1];
	outInt x;
	outFloat k;
	
	x = s[2, 2];
	outInt x;
	x = s1[2, 2];
	outInt x;
	x = s2[2, 2];
	outInt x;
	outFloat k;
	
	x = s[1, 6];
	outInt x;
	x = s1[1, 6];
	outInt x;
	x = s2[1, 6];
	outInt x;
	outFloat k;

	s[2, 5] += 50;
	x = s[1, 6];
	outInt x;
	s1[2, 5] += 50;
	x = s1[1, 6];
	outInt x;
	s2[2, 5] += 50;
	x = s2[1, 6];
	outInt x;

	outFloat k;
	x = s[0, 6];
	outInt x;
	x = s1[0, 6];
	outInt x;
	x = s2[0, 6];
	outInt x;
}
