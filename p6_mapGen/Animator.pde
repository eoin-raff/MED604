class Animator {

                              ///////////////////////////// 1. Phase of the grid ///////////////////////////////
  
  public void AnimationZ (int _boxW, int _boxH, int _boxD, int _boxS, int _i) {
    
    
    if (dimCntrl) {
      translate(0, 0,_boxD);
    } else {
      translate(0, 0,_boxS); // Default setting
    }
    
    
   // translate(0, lerp(_i, planeH,0.1) , lerp(_i, planeH,0.0) + 40 * sin(movement1 + sqrt(_i))); // #1 Oct animation 
    
    rotateX(animaZ_zRot);
    rotateY(0);
    rotateZ(0);
      
  }
  
                              ///////////////////////////// 2. Phase of the grid ///////////////////////////////
  
  public void AnimationY (int _boxW, int _boxH, int _boxD,int _boxS) {

    if (dimCntrl)
      translate(0,_boxH, 0);
      
  }
  
                               ///////////////////////////// 3. Phase of the grid ///////////////////////////////
  
  public void AnimationX (int _boxW, int _boxH, int _boxD,int _boxS, int _j) {


    if (dimCntrl)
       translate(_boxW, 0, 0); 
    else
       translate(boxS, 0, 0); // Default setting
       
       
   // translate(boxS + 10 * sin(movement1 + sqrt(_j)),0, 40 * sin(movement1 + sqrt(_j))); // #1 Oct animation 
    
    rotateX(0);
    rotateY(0);
    rotateZ(0);
      
  }
}
 