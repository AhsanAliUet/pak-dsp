
package converters_pkg;

    function byte float2fix8(real x, shortint fw);
        return byte'(x*(2**fw));
    endfunction

    function shortint float2fix16(real x, shortint fw);
        return shortint'(x*(2**fw));
    endfunction

    function int float2fix32(real x, shortint fw);
        return int'(x*(2**fw));
    endfunction

    function real fix2float16(shortint x, shortint fw);
        //$display("Input to fix2float16: %d(%b)", x, x);
        return real'(x)/(2**fw);
    endfunction

    function real fix2float32(int x, shortint fw);
        //$display("Input to fix2float32: %d(%b)", x, x);
        return real'(x)/(2**fw);
    endfunction

    function real fix2float64(longint x, shortint fw);
        //$display("Input to fix2float64: %d(%b)", x, x);
        return real'(x)/(2**fw);
    endfunction

    function real abs(real x);
        if(x<0) x = -x;
        return x;
    endfunction
endpackage