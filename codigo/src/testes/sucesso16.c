int main(){
	SumArray<int> s[10];
	int i;
	i = 0;
	while(i < 10){
		s[i, i] += i;
		i += 1;
	}
	s[1, 3] += 100;
	int x;
	x = s[1, 3];
	outInt x;
}
