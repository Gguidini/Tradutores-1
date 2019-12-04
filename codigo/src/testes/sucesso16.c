int main(){
	SumArray<int> s[10];
	MinArray<int> s1[10];
	MaxArray<int> s2[10];
	int i;
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
	x = s[1, 3];
	outInt x;
	x = s[1, 1];
	outInt x;
	x = s[2, 2];
	outInt x;
	x = s[1, 6];
	outInt x;
	s[2, 5] += 50;
	x = s[1, 6];
	outInt x;
}
