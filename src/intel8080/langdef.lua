local Intel8080 = require "intel8080.base"
Intel8080.langdef = {}

Intel8080.langdef.opcodes = {
    NOP  = {
        {cmd = 0x00, args = {}},
    },
    LXI  = {
        { cmd = 0x01, args = {{register_pair = "B"},  {word = "data"}}, },
        { cmd = 0x11, args = {{register_pair = "D"},  {word = "data"}}, },
        { cmd = 0x21, args = {{register_pair = "H"},  {word = "data"}}, },
        { cmd = 0x31, args = {{register_pair = "SP"}, {word = "data"}}, },
    },
    STAX = {
        { cmd = 0x02, args = {{register_pair = "B"}}, },
        { cmd = 0x12, args = {{register_pair = "D"}}, },
    },
    INX  = {
        { cmd = 0x03, args = {{register_pair = "B"}}, },
        { cmd = 0x13, args = {{register_pair = "D"}}, },
        { cmd = 0x23, args = {{register_pair = "H"}}, },
        { cmd = 0x33, args = {{register_pair = "SP"}}, },
    },
    INR  = {
        { cmd = 0x04, args = {{register = "B"}}, },
        { cmd = 0x14, args = {{register = "D"}}, },
        { cmd = 0x24, args = {{register = "H"}}, },
        { cmd = 0x34, args = {{register = "M"}}, },
        { cmd = 0x0C, args = {{register = "C"}}, },
        { cmd = 0x1C, args = {{register = "E"}}, },
        { cmd = 0x2C, args = {{register = "L"}}, },
        { cmd = 0x3C, args = {{register = "A"}}, },
    },
    DCR  = {
        { cmd = 0x05, args = {{register = "B"}}, },
        { cmd = 0x15, args = {{register = "D"}}, },
        { cmd = 0x25, args = {{register = "H"}}, },
        { cmd = 0x35, args = {{register = "M"}}, },
        { cmd = 0x0D, args = {{register = "C"}}, },
        { cmd = 0x1D, args = {{register = "E"}}, },
        { cmd = 0x2D, args = {{register = "L"}}, },
        { cmd = 0x3D, args = {{register = "A"}}, },
    },
    MVI  = {
        { cmd = 0x06, args = {{register = "B"}, {byte = "data"}}, },
        { cmd = 0x16, args = {{register = "D"}, {byte = "data"}}, },
        { cmd = 0x26, args = {{register = "H"}, {byte = "data"}}, },
        { cmd = 0x36, args = {{register = "M"}, {byte = "data"}}, },
        { cmd = 0x0E, args = {{register = "C"}, {byte = "data"}}, },
        { cmd = 0x1E, args = {{register = "E"}, {byte = "data"}}, },
        { cmd = 0x2E, args = {{register = "L"}, {byte = "data"}}, },
        { cmd = 0x3E, args = {{register = "A"}, {byte = "data"}}, },
    },
    RLC  = {
        { cmd = 0x07, args = {}, },
    },
    DAD  = {
        { cmd = 0x09, args = {{register_pair = "B"}}, },
        { cmd = 0x19, args = {{register_pair = "D"}}, },
        { cmd = 0x29, args = {{register_pair = "H"}}, },
        { cmd = 0x39, args = {{register_pair = "SP"}}, },
    },
    LDAX = {
        { cmd = 0x0A, args = {{register_pair = "B"}}, },
        { cmd = 0x1A, args = {{register_pair = "D"}}, },
    },
    DCX  = {
        { cmd = 0x0B, args = {{register_pair = "B"}}, },
        { cmd = 0x1B, args = {{register_pair = "D"}}, },
        { cmd = 0x2B, args = {{register_pair = "H"}}, },
        { cmd = 0x3B, args = {{register_pair = "SP"}}, },
    },
    RRC  = {
        { cmd = 0x0F, args = {}, },
    },
    RAL  = {
        { cmd = 0x17, args = {}, },
    },
    RAR  = {
        { cmd = 0x1F, args = {}, },
    },
    SHLD = {
        { cmd = 0x22, args = {{word = "address"}}, },
    },
    DAA  = {
        { cmd = 0x27, args = {}, },
        cmd = 0x27,
    },
    CMA  = {
        { cmd = 0x2F, args = {}, },
        cmd = 0x2F,
    },
    STA  = {
        { cmd = 0x32, args = {{word = "address"}}, },
    },
    STC  = {
        { cmd = 0x37, args = {}, },
    },
    LDA  = {
        { cmd = 0x3A, args = {{word = "address"}}, },
    },
    CMC  = {
        { cmd = 0x3F, args = {}, },
    },
    MOV  = {
        { cmd = 0x40, args = {{register = "B"}, {register = "B"}}, },
        { cmd = 0x41, args = {{register = "B"}, {register = "C"}}, },
        { cmd = 0x42, args = {{register = "B"}, {register = "D"}}, },
        { cmd = 0x43, args = {{register = "B"}, {register = "E"}}, },
        { cmd = 0x44, args = {{register = "B"}, {register = "H"}}, },
        { cmd = 0x45, args = {{register = "B"}, {register = "L"}}, },
        { cmd = 0x46, args = {{register = "B"}, {register = "M"}}, },
        { cmd = 0x47, args = {{register = "B"}, {register = "A"}}, },
        { cmd = 0x48, args = {{register = "C"}, {register = "B"}}, },
        { cmd = 0x49, args = {{register = "C"}, {register = "C"}}, },
        { cmd = 0x4A, args = {{register = "C"}, {register = "D"}}, },
        { cmd = 0x4B, args = {{register = "C"}, {register = "E"}}, },
        { cmd = 0x4C, args = {{register = "C"}, {register = "H"}}, },
        { cmd = 0x4D, args = {{register = "C"}, {register = "L"}}, },
        { cmd = 0x4E, args = {{register = "C"}, {register = "M"}}, },
        { cmd = 0x4F, args = {{register = "C"}, {register = "A"}}, },
        { cmd = 0x50, args = {{register = "D"}, {register = "B"}}, },
        { cmd = 0x51, args = {{register = "D"}, {register = "C"}}, },
        { cmd = 0x52, args = {{register = "D"}, {register = "D"}}, },
        { cmd = 0x53, args = {{register = "D"}, {register = "E"}}, },
        { cmd = 0x54, args = {{register = "D"}, {register = "H"}}, },
        { cmd = 0x55, args = {{register = "D"}, {register = "L"}}, },
        { cmd = 0x56, args = {{register = "D"}, {register = "M"}}, },
        { cmd = 0x57, args = {{register = "D"}, {register = "A"}}, },
        { cmd = 0x58, args = {{register = "E"}, {register = "B"}}, },
        { cmd = 0x59, args = {{register = "E"}, {register = "C"}}, },
        { cmd = 0x5A, args = {{register = "E"}, {register = "D"}}, },
        { cmd = 0x5B, args = {{register = "E"}, {register = "E"}}, },
        { cmd = 0x5C, args = {{register = "E"}, {register = "H"}}, },
        { cmd = 0x5D, args = {{register = "E"}, {register = "L"}}, },
        { cmd = 0x5E, args = {{register = "E"}, {register = "M"}}, },
        { cmd = 0x5F, args = {{register = "E"}, {register = "A"}}, },
        { cmd = 0x60, args = {{register = "H"}, {register = "B"}}, },
        { cmd = 0x61, args = {{register = "H"}, {register = "C"}}, },
        { cmd = 0x62, args = {{register = "H"}, {register = "D"}}, },
        { cmd = 0x63, args = {{register = "H"}, {register = "E"}}, },
        { cmd = 0x64, args = {{register = "H"}, {register = "H"}}, },
        { cmd = 0x65, args = {{register = "H"}, {register = "L"}}, },
        { cmd = 0x66, args = {{register = "H"}, {register = "M"}}, },
        { cmd = 0x67, args = {{register = "H"}, {register = "A"}}, },
        { cmd = 0x68, args = {{register = "L"}, {register = "B"}}, },
        { cmd = 0x69, args = {{register = "L"}, {register = "C"}}, },
        { cmd = 0x6A, args = {{register = "L"}, {register = "D"}}, },
        { cmd = 0x6B, args = {{register = "L"}, {register = "E"}}, },
        { cmd = 0x6C, args = {{register = "L"}, {register = "H"}}, },
        { cmd = 0x6D, args = {{register = "L"}, {register = "L"}}, },
        { cmd = 0x6E, args = {{register = "L"}, {register = "M"}}, },
        { cmd = 0x6F, args = {{register = "L"}, {register = "A"}}, },
        { cmd = 0x70, args = {{register = "M"}, {register = "B"}}, },
        { cmd = 0x71, args = {{register = "M"}, {register = "C"}}, },
        { cmd = 0x72, args = {{register = "M"}, {register = "D"}}, },
        { cmd = 0x73, args = {{register = "M"}, {register = "E"}}, },
        { cmd = 0x74, args = {{register = "M"}, {register = "H"}}, },
        { cmd = 0x75, args = {{register = "M"}, {register = "L"}}, },
        { cmd = 0x77, args = {{register = "M"}, {register = "A"}}, },
        { cmd = 0x78, args = {{register = "A"}, {register = "B"}}, },
        { cmd = 0x79, args = {{register = "A"}, {register = "C"}}, },
        { cmd = 0x7A, args = {{register = "A"}, {register = "D"}}, },
        { cmd = 0x7B, args = {{register = "A"}, {register = "E"}}, },
        { cmd = 0x7C, args = {{register = "A"}, {register = "H"}}, },
        { cmd = 0x7D, args = {{register = "A"}, {register = "L"}}, },
        { cmd = 0x7E, args = {{register = "A"}, {register = "M"}}, },
        { cmd = 0x7F, args = {{register = "A"}, {register = "A"}}, },
    },
    HLT  = {
        {cmd = 0x76, args = {}, },
    },
    ADD  = {
        { cmd = 0x80, args = {{register = "B"}}, },
        { cmd = 0x81, args = {{register = "C"}}, },
        { cmd = 0x82, args = {{register = "D"}}, },
        { cmd = 0x83, args = {{register = "E"}}, },
        { cmd = 0x84, args = {{register = "H"}}, },
        { cmd = 0x85, args = {{register = "L"}}, },
        { cmd = 0x86, args = {{register = "M"}}, },
        { cmd = 0x87, args = {{register = "A"}}, },
    },
    ADC  = {
        { cmd = 0x88, args = {{register = "B"}}, },
        { cmd = 0x89, args = {{register = "C"}}, },
        { cmd = 0x8A, args = {{register = "D"}}, },
        { cmd = 0x8B, args = {{register = "E"}}, },
        { cmd = 0x8C, args = {{register = "H"}}, },
        { cmd = 0x8D, args = {{register = "L"}}, },
        { cmd = 0x8E, args = {{register = "M"}}, },
        { cmd = 0x8F, args = {{register = "A"}}, },
    },
    SUB  = {
        { cmd = 0x90, args = {{register = "B"}}, },
        { cmd = 0x91, args = {{register = "C"}}, },
        { cmd = 0x92, args = {{register = "D"}}, },
        { cmd = 0x93, args = {{register = "E"}}, },
        { cmd = 0x94, args = {{register = "H"}}, },
        { cmd = 0x95, args = {{register = "L"}}, },
        { cmd = 0x96, args = {{register = "M"}}, },
        { cmd = 0x97, args = {{register = "A"}}, },
    },
    SBB  = {
        { cmd = 0x98, args = {{register = "B"}}, },
        { cmd = 0x99, args = {{register = "C"}}, },
        { cmd = 0x9A, args = {{register = "D"}}, },
        { cmd = 0x9B, args = {{register = "E"}}, },
        { cmd = 0x9C, args = {{register = "H"}}, },
        { cmd = 0x9D, args = {{register = "L"}}, },
        { cmd = 0x9E, args = {{register = "M"}}, },
        { cmd = 0x9F, args = {{register = "A"}}, },
    },
    ANA  = {
        { cmd = 0xA0, args = {{register = "B"}}, },
        { cmd = 0xA1, args = {{register = "C"}}, },
        { cmd = 0xA2, args = {{register = "D"}}, },
        { cmd = 0xA3, args = {{register = "E"}}, },
        { cmd = 0xA4, args = {{register = "H"}}, },
        { cmd = 0xA5, args = {{register = "L"}}, },
        { cmd = 0xA6, args = {{register = "M"}}, },
        { cmd = 0xA7, args = {{register = "A"}}, },
    },
    XRA  = {
        { cmd = 0xA8, args = {{register = "B"}}, },
        { cmd = 0xA9, args = {{register = "C"}}, },
        { cmd = 0xAA, args = {{register = "D"}}, },
        { cmd = 0xAB, args = {{register = "E"}}, },
        { cmd = 0xAC, args = {{register = "H"}}, },
        { cmd = 0xAD, args = {{register = "L"}}, },
        { cmd = 0xAE, args = {{register = "M"}}, },
        { cmd = 0xAF, args = {{register = "A"}}, },
    },
    ORA  = {
        { cmd = 0xB0, args = {{register = "B"}}, },
        { cmd = 0xB1, args = {{register = "C"}}, },
        { cmd = 0xB2, args = {{register = "D"}}, },
        { cmd = 0xB3, args = {{register = "E"}}, },
        { cmd = 0xB4, args = {{register = "H"}}, },
        { cmd = 0xB5, args = {{register = "L"}}, },
        { cmd = 0xB6, args = {{register = "M"}}, },
        { cmd = 0xB7, args = {{register = "A"}}, },
    },
    CMP  = {
        { cmd = 0xB8, args = {{register = "B"}}, },
        { cmd = 0xB9, args = {{register = "C"}}, },
        { cmd = 0xBA, args = {{register = "D"}}, },
        { cmd = 0xBB, args = {{register = "E"}}, },
        { cmd = 0xBC, args = {{register = "H"}}, },
        { cmd = 0xBD, args = {{register = "L"}}, },
        { cmd = 0xBE, args = {{register = "M"}}, },
        { cmd = 0xBF, args = {{register = "A"}}, },
    },
    RNZ  = {
        { cmd = 0xC0, args = {}, },
    },
    POP  = {
        { cmd = 0xC1, args = {{register_pair = "B"}}, },
        { cmd = 0xD1, args = {{register_pair = "D"}}, },
        { cmd = 0xE1, args = {{register_pair = "H"}}, },
        { cmd = 0xF1, args = {{register_pair = "PSW"}}, },
    },
    JNZ  = {
        { cmd = 0xC2, args = {{word = "address"}}, },
    },
    JMP  = {
        { cmd = 0xC3, args = {{word = "address"}}, },
    },
    CNZ  = {
        { cmd = 0xC4, args = {{word = "address"}}, },
    },
    PUSH = {
        { cmd = 0xC5, args = {{register_pair = "B"}}, },
        { cmd = 0xD5, args = {{register_pair = "D"}}, },
        { cmd = 0xE5, args = {{register_pair = "H"}}, },
        { cmd = 0xF5, args = {{register_pair = "PSW"}}, },
    },
    ADI  = {
        { cmd = 0xC6, args = {{byte = "data"}}, },
    },
    RST  = {
        {
            cmd = {
                [0] = 0xC7,
                [1] = 0xCF,
                [2] = 0xD7,
                [3] = 0xDF,
                [4] = 0xE7,
                [5] = 0xEF,
                [6] = 0xF7,
                [7] = 0xFF,
            },
            args = {{faux = "address"}},
        },
    },
    RZ   = {
        { cmd = 0xC8, args = {}, },
    },
    RET  = {
        { cmd = 0xC9, args = {}, },
    },
    JZ   = {
        { cmd = 0xCA, args = {{word = "address"}}, },
    },
    CZ   = {
        { cmd = 0xCC, args = {{word = "address"}}, },
    },
    CALL = {
        { cmd = 0xCD, args = {{word = "address"}}, },
    },
    ACI  = {
        { cmd = 0xCE, args = {{byte = "data"}}, },
    },
    RNC  = {
        { cmd = 0xD0, args = {}, },
    },
    JNC  = {
        { cmd = 0xD2, args = {{word = "address"}}, },
    },
    OUT  = {
        { cmd = 0xD3, args = {{byte = "address"}}, },
    },
    CNC  = {
        { cmd = 0xD4, args = {{word = "address"}}, },
    },
    SUI  = {
        { cmd = 0xD6, args = {{byte = "data"}}, },
    },
    RC   = {
        { cmd = 0xD8, args = {}, },
    },
    JC   = {
        { cmd = 0xDA, args = {{word = "address"}}, },
    },
    IN   = {
        { cmd = 0xDB, args = {{byte = "address"}}, },
    },
    CC   = {
        { cmd = 0xDC, args = {{word = "address"}}, },
    },
    SBI  = {
        { cmd = 0xDE, args = {{byte = "data"}}, },
    },
    RPO  = {
        { cmd = 0xE0, args = {}, },
    },
    JPO  = {
        { cmd = 0xE2, args = {{word = "address"}}, },
    },
    XTHL = {
        { cmd = 0xE3, args = {}, },
    },
    CPO  = {
        { cmd = 0xE4, args = {{word = "address"}}, },
    },
    ANI  = {
        { cmd = 0xE6, args = {{byte = "data"}}, },
    },
    RPE  = {
        { cmd = 0xE8, args = {}, },
    },
    PCHL = {
        { cmd = 0xE9, args = {}, },
    },
    JPE  = {
        { cmd = 0xEA, args = {{word = "address"}}, },
    },
    XCHG = {
        { cmd = 0xEB, args = {}, },
    },
    CPE  = {
        { cmd = 0xEC, args = {{word = "address"}}, },
    },
    XRI  = {
        { cmd = 0xEE, args = {{byte = "data"}}, },
    },
    RP   = {
        { cmd = 0xF0, args = {}, },
    },
    JP   = {
        { cmd = 0xF2, args = {{word = "address"}}, },
    },
    DI   = {
        { cmd = 0xF3, args = {}, },
    },
    CP   = {
        { cmd = 0xF4, args = {{word = "address"}}, },
    },
    ORI  = {
        { cmd = 0xF6, args = {{byte = "data"}}, },
    },
    RM   = {
        { cmd = 0xF8, args = {}, },
    },
    SPHL = {
        { cmd = 0xF9, args = {}, },
    },
    JM   = {
        { cmd = 0xFA, args = {{word = "address"}}, },
    },
    EI   = {
        { cmd = 0xFB, args = {}, },
    },
    CM   = {
        { cmd = 0xFC, args = {{word = "address"}}, },
    },
    CPI  = {
        { cmd = 0xFE, args = {{byte = "data"}}, },
    },
}

return Intel8080
