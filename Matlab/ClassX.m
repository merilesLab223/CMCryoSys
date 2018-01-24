classdef ClassX < handle
  properties
      A;
      B;
      C;
  end
  methods
      function obj = method1(obj,a)
          obj.A = a;
      end
  end
end