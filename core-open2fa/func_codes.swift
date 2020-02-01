//
// Created by Vlad Vrublevsky on 01.02.2020.
// Copyright (c) 2020 Vlad Vrublevsky. All rights reserved.
//

enum FUNC_RESULT
{
    case SUCCEFULL

    //ERROR TYPE
    case ALREADY_EXIST
    case FILE_NOT_EXIST
    case FILE_UNVIABLE
    case KEY2FA_NOT_EXIST
    case KEY2FA_INCORRECT

    case ERROR_ON_CATCH
}