
static_assert(sizeof(float) == sizeof(int));
union U {
  float f;
  int i;
};
int main(){
U u;
u.f = 1.0f;
int i = u.i;
return i;
}
