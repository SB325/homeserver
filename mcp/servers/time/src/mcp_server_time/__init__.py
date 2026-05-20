from .server import serve

def main():
    """MCP Time Server - Time and timezone conversion functionality for MCP"""
    import argparse
    import asyncio

    parser = argparse.ArgumentParser(
        description="give a model the ability to handle time queries and timezone conversions"
    )
    parser.add_argument("--local-timezone", type=str, help="Override local timezone")
    parser.add_argument("--transport", type=str, choices=["stdio", "sse"], 
                    default="sse", help="Transport type")
    parser.add_argument("--port", type=int, default=8000, help="Port for SSE server")
    args = parser.parse_args()
    
    asyncio.run(serve(args.local_timezone))


if __name__ == "__main__":
    main()
