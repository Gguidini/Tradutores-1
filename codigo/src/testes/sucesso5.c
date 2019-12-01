int v(int x, int y){
	if(y == 1){
		return x;
	}
	return x * v(x, y-1);
}

int v2(int x, float y){
	return 1.0;
}

int main(){
	int a, b;
	inInt a;
	b = v(v(a, v(4, a)), a);
	a = v2(1, 1.0);
}
