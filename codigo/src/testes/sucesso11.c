int main(){
	int v[10];
	int i;
	i = 0;
	while(i < 10){
		v[i] = i * i;
		i += 1;
	}
	i -= 1;
	while(i >= 0){
		int x;
		x = v[i & (0 - i)];
		outInt x;
		i -= 1;
	}
}
