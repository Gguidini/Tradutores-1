int fat(int x){
	if(x <= 1){
		return 1;
	}
	return x * fat(x-1);
}

int fexp(int b, int e){
	int ans;
	ans = 1;
	while(e != 0){
		if(e & 1){
			ans *= b;
		}
		e /= 2;
		b *= b;
	}
	return ans;
}

MaxArray<int> printArray(int v[], int n){
	int i;
	i = 0;
	while(i < n){
		int x;
		x = v[i];
		v[i] = v[i] - 10;
		outInt x;
		i += 1;
	}
}

int a, b;

int gcd(int a, int b){
	if(b == 0){
		return a;
	}
	return gcd(b, a - (a / b * b));
}

int main(){
	int x;
	inInt x;
	int y;
	y = fat(x);
	outInt y;
	y = fexp(2, x);
	outInt y;
	int v[50], i;
	i = 0;
	while(i < x){
		v[i] = i * i;
		i += 1;
	}
	printArray(v, x);
	printArray(v, x);

	a = x;
	b = 4;
	a += b;

	a = gcd(a, b);

	outInt a;
}
