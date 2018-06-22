classdef AttoCubeDeviceFeature<int32
    enumeration
        Sync    (1)          %/**< "Sync":   Ethernet enabled             */
        Lockin  (2)          %/**< "Lockin": Low power loss measurement   */
        Duty    (4)          %/**< "Duty":   Duty cycle enabled           */
        App     (8)          %/**< "App":    Control by IOS app enabled   */
    end
end

