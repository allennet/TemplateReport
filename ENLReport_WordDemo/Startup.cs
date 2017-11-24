using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(ENLReport_WordDemo.Startup))]
namespace ENLReport_WordDemo
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
