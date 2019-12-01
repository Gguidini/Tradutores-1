int main(){
	int x, y, z;
	z = 10;
	outInt z;
	y = 4;
	outInt y;
	x = 1 + 3 * 7 - 6 + 10 ^ 1 + z * y;
	outInt x;
	y = x * 4 + z * 6 / 2 - 6 * (4 + 5);
	outInt y;
	z = x + y | 6 & (3 + 9 * (z || 0) - y && 1);
	outInt z;
	x += x + y + z;
	outInt x;
	z -= 10;
	outInt z;
	x *= z;
	outInt x;
}
