function [frekans] = note(key)
    frekans=(2^((key-69)/12))*440;
end

